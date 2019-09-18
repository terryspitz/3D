
//pick one shape:
shape = "ellipse"; //["reuleaux", "triangle", "ellipse"]

// ring thickness radius in mm
minor_radius = 1.2;  //[0.5:0.2:4.0]

// ring main radius in mm
major_radius = 11.0; //[7.0:0.5:12.0]

// ratio of z height to minor axis diameter
z_scale = 2.5;  //[0.5:0.5:5.0]

//number of times the cross-section twists as it goes round the ring, fractional twists are possible for cross-sectional shapes with rotational symmetry.
twists = 1.5;  //[0.5:0.5:5]

//use a linear or uneven/oscillating twist around the ring
use_linear = true;

//0: circle, to <1 sharper ellipse
ellipse_eccentricity= 0.8;  //[0.0:0.1:0.9]

function torus(az, theta) = let (
    // A torus with chosen cross-section: 
    // See https://en.wikipedia.org/wiki/Reuleaux_triangle.
    //
    //Args:
    //    az: azimuth: angle around major axis in degrees
    //    theta: [0,360] angle around minor axis in degrees
    
    mod_theta = theta % 120 - 60,
    cos_theta = cos(mod_theta),
    
    linear_twist = az*twists,
    az2 = az+$t*360,
    oscillating_twist = az+(0.9*sin(az2))*twists,
    twist = use_linear ? linear_twist : oscillating_twist,
    
    // Use Polar equation of a circle from https://en.wikipedia.org/wiki/Polar_coordinate_system#Circle
    // R=1, r0=1/sqrt(3) (2/3 height of unit sided equilateral triangle, offset of centre of reuleaux arc)
    r_reuleaux = sqrt(4*cos_theta*cos_theta + 8)/2 - cos_theta,
    degrees = (twist+30) % 120 - 30,
    //echo(twist, degrees),
    r0_reuleaux = (degrees<30) ?
        sqrt(3)-cos(degrees) + sqrt(3)/2
        : cos(degrees-60) + sqrt(3)/2,
    
    // or triange cross-section:
    r_triangle = 1/cos_theta,
    r0_triangle = 0,
    
    // or ellipse:
    r_ellipse =  1/sqrt(1 - pow(ellipse_eccentricity * cos(theta),2)),
    r0_ellipse = 0,
    
    r = shape=="reuleaux" ? r_reuleaux : shape=="triangle" ? r_triangle : shape=="ellipse" ? r_ellipse : error,
    r0 = shape=="reuleaux"  ? r0_reuleaux : shape=="triangle" ? r0_triangle : shape=="ellipse" ? r0_ellipse : error,
    
    theta2 = theta + twist,  //twist it!

    //groove
    minor_radius2 = minor_radius * ((theta+270) % 90 < 10 ? 0.7 : 1.0),
    full_radius = major_radius + minor_radius2 * (r * cos(theta2) - r0),
    //based on parametric equation of a torus
    x = sin(az) * full_radius,
    y = cos(az) * full_radius,
    z = r * sin(theta2) * minor_radius * z_scale
    ) 
    [x, y, z];
    

az_step = 3.6+0;
theta_step = 10+0;

//for debugging, show slices of the surface: use 1 for continuous, or higher for just slices
zebra = 1;  //[1:4]

polyhedron(
    points = [for(az = [0:az_step*zebra:360+1], theta = [0:theta_step:360-1])
                torus(az, theta)],
    faces = let (step = floor(360/theta_step))
            concat(
                [for (i = [0:step:360/az_step/zebra*step], j=[0:360/theta_step])
                    [i+j,i+step+(j+1)%step,i+(j+1)%step]],
                [for (i = [0:step:360/az_step/zebra*step], j=[0:360/theta_step])
                    [i+step+(j+1)%step, i+j, i+step+j]]
            )
);
